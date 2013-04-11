// <copyright file="UsedImplicitlyAttribute.cs" company="JetBrains s.r.o.">
// Copyright 2007-2012 JetBrains s.r.o.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// </copyright>

namespace JetBrains.Annotations
{
    using System;
    using System.Diagnostics.CodeAnalysis;

    /// <summary>Indicates that the marked symbol is used implicitly (e.g. via reflection, in external library),
    /// so this symbol will not be marked as unused (as well as by other usage inspections)</summary>
    [AttributeUsage(AttributeTargets.All, AllowMultiple = false, Inherited = true)]
    public sealed class UsedImplicitlyAttribute : Attribute
    {
        [UsedImplicitly]
        [SuppressMessage("StyleCop.CSharp.DocumentationRules", "SA1600:ElementsMustBeDocumented", Justification = "Jetbrains code")]
        public UsedImplicitlyAttribute()
            : this(ImplicitUseKindFlags.Default, ImplicitUseTargetFlags.Default)
        {
        }

        [UsedImplicitly]
        [SuppressMessage("StyleCop.CSharp.DocumentationRules", "SA1600:ElementsMustBeDocumented", Justification = "Jetbrains code"), SuppressMessage("Microsoft.Naming", "CA1726:UsePreferredTerms", MessageId = "Flags", Justification = "Jetbrains code")]
        public UsedImplicitlyAttribute(ImplicitUseKindFlags useKindFlags, ImplicitUseTargetFlags targetFlags)
        {
            this.UseKindFlags = useKindFlags;
            this.TargetFlags = targetFlags;
        }

        [UsedImplicitly]
        [SuppressMessage("StyleCop.CSharp.DocumentationRules", "SA1600:ElementsMustBeDocumented", Justification = "Jetbrains code"), SuppressMessage("Microsoft.Naming", "CA1726:UsePreferredTerms", MessageId = "Flags", Justification = "Jetbrains code")]
        public UsedImplicitlyAttribute(ImplicitUseKindFlags useKindFlags)
            : this(useKindFlags, ImplicitUseTargetFlags.Default)
        {
        }

        [UsedImplicitly]
        [SuppressMessage("StyleCop.CSharp.DocumentationRules", "SA1600:ElementsMustBeDocumented", Justification = "Jetbrains code"), SuppressMessage("Microsoft.Naming", "CA1726:UsePreferredTerms", MessageId = "Flags", Justification = "Jetbrains code")]
        public UsedImplicitlyAttribute(ImplicitUseTargetFlags targetFlags)
            : this(ImplicitUseKindFlags.Default, targetFlags)
        {
        }

        [UsedImplicitly]
        [SuppressMessage("StyleCop.CSharp.DocumentationRules", "SA1600:ElementsMustBeDocumented", Justification = "Jetbrains code"), SuppressMessage("Microsoft.Naming", "CA1726:UsePreferredTerms", MessageId = "Flags", Justification = "Jetbrains code")]
        public ImplicitUseKindFlags UseKindFlags { get; private set; }

        /// <summary>Gets value indicating what is meant to be used</summary>
        [UsedImplicitly]
        [SuppressMessage("Microsoft.Naming", "CA1726:UsePreferredTerms", MessageId = "Flags", Justification = "Jetbrains code")]
        public ImplicitUseTargetFlags TargetFlags { get; private set; }
    }
}