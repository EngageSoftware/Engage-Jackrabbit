// <copyright file="InvokerParameterNameAttribute.cs" company="JetBrains s.r.o.">
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

    /// <summary>Indicates that the function argument should be string literal and match one of the parameters
    /// of the caller function.
    /// For example, ReSharper annotates the parameter of <see cref="System.ArgumentNullException" />.</summary>
    /// <example>
    ///   <code>
    /// public void Foo(string param)
    /// {
    /// if (param == null)
    /// throw new ArgumentNullException("par"); // Warning: Cannot resolve symbol
    /// }
    ///   </code>
    /// </example>
    [AttributeUsage(AttributeTargets.Parameter, AllowMultiple = false, Inherited = true)]
    public sealed class InvokerParameterNameAttribute : Attribute
    {
    }
}